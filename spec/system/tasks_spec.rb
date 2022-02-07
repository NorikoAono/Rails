require 'rails_helper'

describe 'タスク管理機能', type: :system do
    let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com') }
    let(:user_b) { FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com') }
    let!(:task_a) { FactoryBot.create(:task, name: '最初のタスク', user: user_a )}

    before do
        # ユーザーでログインする
        visit login_path
        fill_in 'メールアドレス', with: login_user.email
        fill_in 'パスワード', with: login_user.password
        click_button 'ログインする'
    end

    shared_examples_for 'ユーザーAが作成したタスクが表示される' do
        it { expect(page).to have_content '最初のタスク'}
    end

    describe '一覧表示機能' do
        context 'ユーザーAがログインしているとき' do
            let(:login_user) { user_a }

            it_behaves_like 'ユーザーAが作成したタスクが表示される'
        end

        context 'ユーザーBがログインしているとき' do 
            let(:login_user) { user_b }

            it 'ユーザーAが作成したタスクが表示されない' do
                # ユーザーAが作成したタスクの名称が画面上に表示されていないことを確認
                expect(page).to have_no_content '最初のタスク'
            end
        end
    end

    describe '詳細表示機能' do
        context 'ユーザーAがログインしているとき' do
            let(:login_user) { user_a }

            before do
                visit task_path(task_a)
            end

            it_behaves_like 'ユーザーAが作成したタスクが表示される'
        end
    end

    describe '新規作成機能' do
        let(:login_user) { user_a }

        before do
            visit new_task_path
            fill_in '名称', with: task_name
            click_button '登録する'
        end

        context '新規作成画面で名称を入力したとき' do
            let(:task_name) { '新規作成のテストを書く' }

            it '正常に登録される' do
                expect(page).to have_selector '.alert-success', text: '新規作成のテストを書く'
            end
        end

        context '新規作成画面で名称を入力しなかったとき' do 
            let(:task_name) { '' }

            it 'エラーとなる' do
                within '#error_explanation' do
                    expect(page).to have_content '名称を入力してください'
                end
            end
        end

        context '新規作成画面で30文字を超えた名称を入力したとき' do 
            let(:task_name) { 'スーパーエバグリーン宮前店でカレーのルーとにんじんとじゃがいもを買う' }

            it 'エラーとなる' do
                within '#error_explanation' do
                    expect(page).to have_content '名称は30文字以内で入力してください'
                end
            end
        end

        context '新規作成画面でカンマを含む名称を入力したとき' do 
            let(:task_name) { 'カンマ,を含む入力をする' }

            it 'エラーとなる' do
                within '#error_explanation' do
                    expect(page).to have_content '名称にカンマを含めることはできません'
                end
            end
        end
    end

    describe '更新機能' do
        let(:login_user) { user_a }

        before do
            visit edit_task_path
            fill_in '名称', with: task_name
            click_button '更新する'
        end

        context '更新画面で名称がブランクでないとき' do
            let(:task_name) { '名称を更新する' }

            it '正常に更新される' do
                expect(page).to have_selector '.alert-success', text: '名称を更新する'
            end
        end

        context '更新画面で名称をブランクにしたとき' do 
            let(:task_name) { '' }

            it 'エラーとなる' do
                within '#error_explanation' do
                    expect(page).to have_content '名称を入力してください'
                end
            end
        end
    end

    describe '削除機能' do
        let(:login_user) { user_a }

        context '一覧画面で削除ボタンを押したとき' do
            let(:task_name) { 'タスクを削除する' }

            before do
                click_button '削除する'
            end

            it 'タスクが削除される' do
                expect(page).to have_selector '.alert-success', text: 'タスクを削除する'
            end
        end

        context '詳細画面で削除ボタンを押したとき' do 
            let(:task_name) { '詳細画面でタスクを削除する' }

            before do
                visit task_path(task_a)
                click_button '削除する'
            end

            it 'タスクが削除される' do
                expect(page).to have_selector '.alert-success', text: '詳細画面でタスクを削除する'
            end
        end
    end
end
        
